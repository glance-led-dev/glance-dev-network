# Denison Men's Track & Field for Glance

A 192×32 Glance app with eight rotating pages:

1. Denison title card
2. Next scheduled meet
3. Following meet
4. Most recent team result
5. Prior team result
6. Jack Meyerowitz's latest 2025–26 result
7. Jack's current college bests and All-NCAC count
8. Latest official men's track & field news

The schedule, results, and news come from Denison Athletics. During the offseason,
the upcoming-meet pages display a clear “schedule coming soon” message. If the
official sources are temporarily unavailable, the app uses a small bundled
2025–26 fallback rather than showing a blank screen.

## Preview

From the root of the Glance Developer Network repository:

```bash
gdn studio apps/denison-mens-track
```

Or validate and render from the terminal:

```bash
gdn validate apps/denison-mens-track
gdn render apps/denison-mens-track --page home --out denison-home.png
```

## Publishing

Use **Validate & Submit** in Glance Dev Studio, or:

```bash
gdn submit apps/denison-mens-track
```

That opens a GitHub pull request for Glance's catalog review. The app contains
no credentials or private API keys.

## Sources and maintenance

- Schedule/results: `https://denisonbigred.com/sports/mens-track-and-field/schedule`
- News: `https://denisonbigred.com/rss.aspx?path=mtrack`
- Jack's college bests: TFRRS snapshot current through the 2025–26 season

The Sidearm schedule HTML is parsed defensively, but a major redesign of
Denison's athletics site could require updating the selectors in `app.star`.
Jack's latest-result and college-bests pages are intentionally curated snapshots
and should be updated when he posts new results or personal bests. The team
schedule, team results, and news pages update from Denison automatically.
