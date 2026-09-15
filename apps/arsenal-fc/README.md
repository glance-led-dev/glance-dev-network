# Arsenal FC

## cannon.png provenance

`assets/cannon.png` is derived from **Arsenal F.C.'s own 1921–22 club crest**
— "the crest is a westward pointing single cannon," adopted for one season
and then replaced. It is in the public domain (published before 1931; see
the file's own licensing block) and is documented as uncopyrighted by
Arsenal's own crest history:

- Source: https://commons.wikimedia.org/wiki/File:Arsenal_F.C._Crest_1921%E2%80%931922.png
- Citing: https://www.arsenal.com/news/news-archive/the-arsenal-crest

The original is a detailed line illustration; at this panel's pixel budget
it was thresholded to a single color and reduced to 20x9 px (majority-vote
per cell, no anti-aliasing, no interpolation) so it draws as clean pixel art
rather than a blurred photo. The lit pixels are Arsenal red (#EF0107) on a
transparent ground, so the mark stands directly on the app's black panel. The modern shield crest (with the "Arsenal"
wordmark, gold trim, and three colored panels) was tried first and does not
survive reduction to panel resolution — it becomes an unreadable smear even
at 24x24px — which is why this simpler, single-element historical crest was
used instead.

Wikimedia's file page notes that although the image itself is out of
copyright, "this image shows ... an official insignia" and related
trademark rights are independent of copyright status and vary by
jurisdiction.

## Football-data.org API key (optional)

RESULT normally uses TheSportsDB's shared free key, no setup needed. That
key's `eventslast.php` endpoint has been observed serving a stale "last
result" for Arsenal specifically — for example, it kept returning a Sept 6
result days after Arsenal had already played and won a newer match on
Sept 12, even though other endpoints (next fixture, standings) were
current. Every alternative free TheSportsDB endpoint tried (season
schedule, past-league results, round-by-round, day-by-day) is capped to a
handful of items by the shared key and doesn't reliably include Arsenal's
match either — there's no free/keyless fix for this.

If you hit this, get a free API key from football-data.org
(https://www.football-data.org/client/register — free tier, no credit
card) and paste it into the app's "Football-data.org API key" input. When
present, RESULT tries football-data.org first (it resolves Arsenal's team
id by name against the Premier League roster rather than a hardcoded
guess) and only falls back to the free TheSportsDB source if that request
itself fails — so a genuinely quiet week (no finished match) still shows
correctly either way. Leave the key blank to keep using the free source
as before.
