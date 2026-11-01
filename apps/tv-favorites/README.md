\# TV Favorites



Shows when your favorite live TV shows air, with your local channel numbers and times in your own time zone. Show data comes from TVMaze.



\## Pages

\- \*\*Today\*\*: favorites airing today. One show shows full details. Two or more show a compact list of up to 3, with "+N MORE" beyond that.

\- \*\*Tomorrow\*\*: the same, for tomorrow.

\- \*\*Later\*\*: your next upcoming show, two or more days out.

\- \*\*Stream\*\*: shows from your stream list that aired yesterday, as a reminder of what to catch up on.



\## Setup

1\. Create a file named `channels.json` using the format below.

2\. Host it somewhere public. A GitHub raw URL works well.

3\. In the app settings, paste the URL without `https://` into \*\*Config URL\*\*.

4\. Set \*\*UTC Offset\*\* to your time zone, for example -6 for Mountain Daylight Time.



With no Config URL the app shows a demo.



\## Config format

```json

{

&#x20; "channels": \[

&#x20;   {"num": "4.1", "callsign": "KAMR", "network": "NBC"}

&#x20; ],

&#x20; "favorites": \[

&#x20;   {"title": "Survivor", "abbr": "SUR", "seasons": \["fall", "spring"]}

&#x20; ],

&#x20; "stream": \[

&#x20;   {"title": "99 to Beat", "abbr": "99", "service": "Hulu", "seasons": \["fall"]}

&#x20; ]

}

```



\- \*\*channels\*\*: maps a network name (as TVMaze lists it, such as NBC or CBS) to your local channel number and call sign. Networks you don't list show as the network name.

\- \*\*favorites\*\*: live shows you want to watch as they air.

\- \*\*stream\*\*: shows you plan to stream. They appear on the Stream page the day after they air.

\- \*\*title\*\*: the show's name. It must be close to the TVMaze name, so check tvmaze.com.

\- \*\*abbr\*\*: a short label (3 characters or fewer) for list views.

\- \*\*service\*\* (stream only): where you watch it.

\- \*\*seasons\*\*: when to check the show. Use any of `fall` (Sep-Dec), `winter` (Jan-Mar), `spring` (Apr-Jun), `summer` (Jul-Aug), or `all`. An empty list switches the show off.



\## Limits

The Glance platform restricts how many web requests an app can make for each screen update. The app checks only the \*\*first 7 in-season shows\*\* in each list, in file order. Put the shows you care about most at the top.



\## Notes

\- TVMaze times are Eastern. The app converts them using your UTC Offset.

\- The offset is manual. Change it when your clocks change.

\- Times come from TVMaze and may differ from your local station's listings.

