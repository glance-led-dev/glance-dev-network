# Household Attention for Glance LED

A 192×32 SCROLL component for Household Intelligence. This is a Glance Developer Network Starlark app, not a Go-template widget for the unrelated Glance web dashboard.

The display shows a household attention count or one explicitly shared ranked title. Choose rank 1–5 in settings. A missing rank falls back to the total count. Failed sources are always labelled CHECK SOURCES. Expired feeds show DATA STALE instead of an old title. Zero items means no due items in connected data; it does not imply every household device is healthy.

## Private deployment boundary

Keep the household management app on the private network. Glance's hosted renderer cannot use a private LAN management address. A separate authenticated relay must receive only the approved minimal payload. Do not expose the management server, give Glance an administrator credential, reuse a vendor token, or disable TLS verification.

Use a dedicated relay read credential in the `readkey` api-key input and a verified HTTPS relay URL in `endpoint`. Both full HTTPS URLs and hostname/path input work. Plain HTTP, embedded credentials, ports, fragments and query strings are rejected before authentication is sent.

Each installation needs its own authenticated relay implementing the contract below. Building this package does not provision that relay or install the app on a physical display. Catalogue availability, relay operation and display delivery must be verified separately.

## Feed contract

The response is a JSON object with `schema: 1`, UTC epoch-second `generated_unix` and `expires_unix`, nonnegative integer `total_actionable`, boolean `degraded`, `source_count`, privacy mode `counts` or `titles`, and an `items` list. Expiry may be no more than 300 seconds after generation. Reject missing timestamps; do not substitute the renderer time for an old source snapshot.

In counts mode, `items` is empty. In titles mode, at most five items contain only `title` and `stale`. Do not add notes, record IDs, source IDs, home addresses, account names, calendars, precise locations, device identifiers, links, or credentials. The household service's projection defaults to counts mode; title sharing requires an explicit choice.

## Preview and verify

`gdn check <app-directory>` and `gdn validate <app-directory>` validate the package. `gdn build <app-directory> --input preview=Item` renders an offline example. Offline states include Counts, Item, Empty, Stale, Error and Long title; all show SAMPLE and perform no network requests. Leave preview set to Live for production.

Local checks cover privacy projection, rejected endpoints, authentication headers, expiry, source warnings, and safe-area text bounds. Also verify the live relay's unauthenticated denial, invalid publisher denial, expiry after publisher failure, recovery, actual rendered image, and physical display settings before calling deployment complete.

## Extending

Add household sources and rules in the private application. Preserve this small display contract so new devices do not require a different LED app. The renderer stays read-only and contains no device-control operation. Longer explanations, evidence and actions belong in the authenticated household GUI.
