# Package Tracker for Glance Scroll

A 192x32 GDN app for package status. Each view retains the carrier logo, sender and last four tracking digits. No package contents are guessed.

## Display behavior

- Four pages: expected delivery, latest status/location, last carrier scan, and origin/destination.
- Every undelivered, unarchived FedEx, UPS and USPS shipment stays eligible, including label-created, delayed, unknown and delivery-attempted shipments.
- A different shipment is selected each minute. The four page functions use the same selection within that minute. A render crossing the minute boundary may switch shipment; the persistent identity makes the switch visible.
- Five progress segments represent label / acceptance / transit / final delivery stage / delivered. This is not distance or percentage completion. Delivered shipments leave the rotation.
- Long carrier messages and location text continue across later passes. Long senders are fitted separately so the tracking suffix stays visible.
- Missing sender: `SENDER UNKNOWN`. Missing date: `DELIVERY PENDING`. Missing window: `TIME NOT PROVIDED`. Missing location remains unknown, rather than inferring it from unrelated events.
- Scan times are labeled and provided by the discovery service. They are the most recent reported scan, not GPS tracking. Email fallback timestamps are separately labeled LAST CARRIER EMAIL; email notices may omit locations and scan details.
- Feed/authorization errors, overdue data and disconnected discovery are visible. Demonstration data appears only when explicitly selected.

## Setup

1. Copy this folder into `apps/package-tracker` in a Glance Developer Network checkout, or open this folder directly in Glance Studio.
2. Start with a **Preview scenario** such as UPS, FedEx or USPS. No credentials are needed for demos.
3. Set up the accompanying `package-discovery` service for automatic Gmail discovery and carrier tracking (included as `service/` in the release package).
4. Enter its HTTPS `/status` URL and separate read-only key. The key input uses GDN's encrypted `api-key` type.
5. Switch Preview scenario to **Live**.

Production defaults are Live with empty connection settings. Each user supplies their own authenticated feed. See [service setup](service/README.md) for the free direct-carrier and Gmail options.

## Feed contract

The app accepts an authenticated JSON response with `schema_version: 1`, `generated_at` (Unix seconds), and a `shipments` array. Each item can contain:

```json
{
  "carrier": "UPS",
  "sender": "EXAMPLE STORE",
  "tracking_last4": "4821",
  "status": "in_transit",
  "stage": 2,
  "expected_date": "TUE SEP 29",
  "delivery_window": "2:00-6:00 PM",
  "latest_message": "DEPARTED FACILITY",
  "latest_location": "MEMPHIS, TN",
  "scan_time": "SEP 26 9:42 AM CT",
  "origin": "AUSTIN, TX",
  "destination": "NEW YORK, NY",
  "stale": false
}
```

This example is fictional. Date/window strings must come from the provider; absent values should remain empty. Full tracking numbers, email addresses, street addresses, email bodies and service credentials are not part of this feed.

## Validation

Run from an environment with the GDN dependencies:

```text
python tests/render_check.py
gdn validate .
```

The render harness checks all demo scenarios through the real Starlark host, text bounds, edge padding, persistent identity, rotation, delivered filtering and error handling. `preview/carrier-gallery.png` contains the actual rendered pixels. Live mailbox authorization, tracking availability and deployment require the user's accounts and are not validated by these offline tests.
