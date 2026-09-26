# Automatic package discovery and tracking

Gmail discovery uses the Windows IMAP helper with an app password; see [Windows setup](imap/README.md). It reads matching mail without changing read state and uploads tracking references, merchant display names, and recognized carrier notification fields. It does not upload mail bodies.

## Free carrier connection

FedEx uses Basic Integrated Visibility directly. Create a developer project, link a shipping account, enable production access, and store FEDEX_CLIENT_ID and FEDEX_CLIENT_SECRET as Worker secrets. Each scheduled run obtains a short-lived access token automatically; browser sign-in is not needed while the credentials remain valid. No paid FedEx webhook products are used.

The adapter requests detailed scans, maps status and coarse locations, preserves carrier delivery dates/windows, and excludes delivered packages. Missing data stays unknown. Ambiguous/recycled tracking-number results are rejected.

UPS uses its standard Tracking product and required OAuth, with UPS_CLIENT_ID and UPS_CLIENT_SECRET in Worker secrets. The adapter renews access tokens automatically, requests neither signatures nor delivery photos, and preserves scheduled/rescheduled delivery windows. Premium Track Alert products are not used. Credentials must be issued by UPS before this adapter can run.

UPS and USPS have a free email fallback. The IMAP helper accepts a recognized subject only from an aligned, Gmail-authenticated carrier sender and a message containing one package. Ambiguous digests are skipped. Newer notifications replace older email data; delivered is terminal and API data takes precedence. Only explicitly labeled delivery dates are parsed. Email timestamps are labeled LAST CARRIER EMAIL, never as scans. Locations remain unknown unless another source supplies them. Notification data older than 24 hours is marked overdue. This does not provide every carrier scan, and discovery alone does not prove a package is undelivered. UPS API access requires developer credentials; USPS uses email notifications.

Legacy EasyPost is disabled unless both ALLOW_PAID_TRACKING = "true" and EASYPOST_API_KEY are explicitly configured. A key alone cannot enable paid calls.

## Configure

1. Copy wrangler.toml.example to a private wrangler.toml and configure D1.
2. Apply schema.sql.
3. Keep DISCOVERY_MODE = "imap" and set DELIVERY_TIMEZONE for scan timestamps.
4. Configure separate random READ_KEY and WRITE_KEY Worker secrets plus both FedEx secrets.
5. Connect the Windows helper using Windows Credential Manager. Never place credentials in source or configuration files.
6. Run node --test test/*.test.mjs and deploy. The schedule runs every 15 minutes and refreshes up to 15 eligible shipments, least recently checked first.
7. Configure Glance with the private /status URL and encrypted read key.

Cloudflare quotas apply. This service does not change your subscription or activate paid tracking. IMAP discovery requires the Windows computer to be awake and signed in.

## Endpoints and data

- GET /status requires READ_KEY. Returns only last-four tracking digits and display data. carrier_status reports carriers separately; tracking_connected is per shipment.
- POST /discover requires WRITE_KEY. Accepts validated batches of at most 25 references and discovery heartbeats in IMAP mode.
- POST /refresh requires WRITE_KEY. Runs the same bounded update as the schedule. READ_KEY cannot trigger it.

Failures preserve previous data and mark it stale. Delivered records are excluded; other records remain unless archived in D1. Full tracking numbers stay privately in D1 for lookup. No mail bodies, attachments, street addresses or credentials are included in the feed. Polling frequency does not imply new carrier scans at that frequency.

Optional Gmail OAuth remains available with DISCOVERY_MODE = "oauth" and GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_REFRESH_TOKEN. It is not required for IMAP.

## Validation

Tests cover discovery, identity, privacy, delivered removal, FedEx dates/windows/time zones, failure retention, token renewal, carrier-specific status, and the paid-provider gate. Rendering checks cover 44 Scroll pages. Offline fixtures do not establish real shipment accuracy; production authentication and actual shipment lookup must be reported separately.

References: [FedEx tracking](https://developer.fedex.com/api/en-us/catalog/track/v1/docs.html), [FedEx authentication](https://developer.fedex.com/api/en-us/catalog/authorization/docs.html).
