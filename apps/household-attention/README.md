# Household Attention for Glance LED

A 384x32 scrolling strip: source logo | task and context | contextual artwork. Five pages rotate the top five ranked items; choose Fixed rank only to pin one item. Shopping entries show SHOPPING LIST. Source failure and expiry remain explicit. A healthy feed does not imply every household device is connected.

## Configuration

Use your authenticated HTTPS LED relay in endpoint and its dedicated read credential in readkey. Keep preview=Live and mode=All five. Never expose a management endpoint or use an administrator/vendor token here. Catalogue release, relay health and physical delivery are separate checks.

## Feed contract

JSON schema=1; integer generated_unix and expires_unix (maximum 300-second lifetime); nonnegative integer total_actionable and source_count; boolean degraded; privacy=counts or titles; items contains at most five entries and is empty in counts mode.

Each title entry contains title (160 characters maximum), boolean stale, optional source_label/context (64 uppercase ASCII characters), optional brand (google-tasks, google-calendar, alexa, whisker, petlibro or empty), optional item_kind=shopping, and optional logo_key (lowercase letters, digits and hyphens, 40 characters maximum). Optional logo_pixels is exactly 26 rows of 62 hexadecimal RGB colors (#RRGGBB), prepared by the private publisher. Invalid pixels fall back to a bundled category icon. Images are data, never URLs or code. Bound the complete feed to 100000 bytes.

The private publisher matches known brands locally, caches resized artwork and sends pixels. Adding cached artwork needs no app asset update. Prefer explicit names and contextual matches; do not guess product brands. Personal imagery belongs in the authenticated private feed, not the public package. No notes, record/device identifiers, account names, exact locations, tokens, or management links belong in this projection. Title, context and artwork sharing must be opted into separately.

## Verify and extend

Run gdn check and gdn validate on this directory. Offline previews are marked SAMPLE and perform no requests. Verify authenticated reads, denied anonymous/wrong-purpose requests, expiry and recovery, then the physical panel. This app uses platform-controlled pages, not simulated animation.

Version 0.3.0 requires a publisher/relay that accepts the optional logo fields. Older feeds remain readable. Deploy backward-compatible relay validation before enabling artwork publishing. The runtime image API only accepts bundled assets; bounded pixel drawing permits new contextual artwork without remote image execution.

Bundled Google Tasks/Calendar product icons use Google's published product artwork; Alexa uses its brand mark; Litter-Robot and PETLIBRO use their reporting-device wordmarks. Generic category icons are original UI artwork. Trademarks belong to their respective owners; no endorsement is implied. Dynamic personal photos and example household records are not included.
