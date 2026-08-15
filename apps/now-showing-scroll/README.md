# Now Showing (Scroll)

Now Showing is one movie or TV show/episode, always on the panel: title, runtime, genre, and IMDb + Rotten Tomatoes ratings (each color-coded red/amber/green).

Layout is a stacked "NOW / SHOWING" label on the left, then three lines: title (with release year and season/episode if set) and runtime, genre, and the two ratings. Data comes from OMDb (omdbapi.com), using the viewer's own free API key — an optional release year helps disambiguate remakes/reboots that share a title.

This is the 192px-wide Scroll build of [Now Showing](../now-showing) — same layout and data, sized for the Scroll panel instead of LED V2. At this width the title/genre lines shrink and truncate (instead of running past the panel) when they're too long even at the smallest font, and the Rotten Tomatoes rating drops before the ratings row would overflow.

![Now Showing (Scroll) preview](preview/preview.png)

## Configuration

- **Movie or show** — Movie or Show.
- **Title** — exact title to look up.
- **Release year** (optional) — narrows down remakes/reboots sharing a title.
- **Season #** / **Episode #** (shows only, optional) — leave both blank to show overall series info instead of one episode.
- **OMDb API key** — required; free from omdbapi.com/apikey.aspx.
- **"Now Showing" label color** — color of the stacked label.
