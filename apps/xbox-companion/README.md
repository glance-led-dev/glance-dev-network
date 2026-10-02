# Xbox Companion for Glance

A 192x32 community-app prototype with Profile, Now Playing / Last Played, Recent Achievement, Gamerscore, Recent Activity and Friend Activity cards.

## Self-hosting

Live data comes from a companion service you host yourself. The companion's source and setup guides are not part of this catalog package, because Glance app folders ship the Starlark app and its assets only. Each user runs one companion, registers their own Microsoft app and connects their own Xbox account. No shared backend or author-owned Azure credentials are included. The companion encrypts its saved refresh token, updates every four minutes, and exposes a read-key-protected snapshot for Glance.

There are two deployment options. A standalone Docker companion needs an always-on Docker host and a public HTTPS address through your own reverse proxy. Alternatively, a Cloudflare Worker hosts the sign-in page and snapshot feed, while your Linux server collects data over outbound HTTPS. It needs no inbound server port or Azure hosting. Both options use your own Microsoft registration and credentials; no community workload runs on the author's server.

Glance cannot fetch a private LAN or localhost address. Self-hosting shifts operating costs to the user; this package does not provision a paid cloud service.

## Display setup

Enter your companion hostname and `/status` path, such as `xbox.example.com/status`, in **Companion status host/path**. Omit `https://`: its colon can truncate the device's settings descriptor. The app adds HTTPS when fetching the snapshot. Enter READ_KEY in **Device read key** and keep **Preview scenario** set to **Live**. Friends require opt-in both in your server configuration and the display settings. Fictional demo scenarios work without a backend.

After this app update is available, edit an existing installation's endpoint to remove only the `https://` prefix, keep the hostname/path and existing device key, then save. The input keys are unchanged. Full HTTPS URLs remain accepted for legacy settings and Studio, but use hostname/path on the physical device. Public HTTPS hosting is still required; this change does not alter the companion's PUBLIC_URL or Microsoft redirect URI.

The display refreshes every five minutes, as required for apps with text and API-key settings. The companion continues collecting a snapshot every four minutes. Glance caches the HTTP response for 60 seconds, and snapshots older than five minutes still show a stale warning.

The app is not yet published in the catalogue. Use the GDN development workflow until catalogue publication is complete. Catalogue availability depends on maintainer review and merge.

## Data and behavior

- Last Played uses the newest returned game play timestamp. Current-game artwork matches title ID where available; missing images use the Xbox symbol.
- Recent Activity uses achievement title history with matching achievement artwork or game cover. It is distinct from complete play history.
- Friend activity checks up to 20 contacts and displays only disclosed online activity. No messages or friends achievement histories are fetched.
- Snapshots older than five minutes show a stale warning. Refresh failures can require reconnection.
- Static cards use Glance bitmap fonts. Auto currently selects current activity or Profile; individual views can be selected. Smooth animation is not supported by the current runtime.

## Validation and limitations

Every **Preview scenario** renders fictional data without a backend, so the display can be checked in Glance Dev Studio before a companion is running.

The original live prototype verified Microsoft/Xbox authentication, profile, achievements, shared friend presence, TitleHub play timestamps and Microsoft Store artwork. Thirty rendering/behavior checks and GDN validation passed. The packaged companion's offline tests cover authorization, CSRF, PKCE, callback replay, encrypted token storage and exclusion of credentials from status output. Docker is unavailable in the development environment, so container execution and unattended refresh are not claimed as tested. Each deployment still needs end-to-end verification.

The optional Cloudflare/Linux deployment has also been verified with a live account, encrypted credential provisioning, automatic refresh-token renewal, and collector recovery after a Linux reboot. Its Worker tests cover authentication, CSRF, PKCE, callback replay, encrypted handoff, separate administrator/read/write keys, and snapshot filtering. This does not establish Docker execution or physical-device delivery.

TitleHub currently worked with the prototype identity but its public production support contract remains unverified. Upstream changes, privacy settings and throttling can affect availability.

## Assets and credentials

Xbox symbols derive from the official website asset https://uhf.microsoft.com/images/xbox/RW4ESm.png under permission supplied by the project owner. This does not imply Microsoft endorsement or transfer brand rights to other uses. Live artwork comes from Microsoft's services.

Never commit `.env`, tokens, account snapshots or personal screenshots. Keep the app client secret, encryption key and administrator key out of Glance. Only the device READ_KEY belongs in its encrypted API-key input.
