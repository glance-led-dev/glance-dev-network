# Shopify Orders Today (GLANCE SCROLL, 192x32)

Order counts only. The app requests no prices, so it cannot display any money.

* **ORDERS TODAY**: running count since local midnight (big, white).
* **+N THIS HR**: orders placed in the current local clock hour. Resets at :00.
* **7D HIGH N**: highest single-day count over the rolling last 7 days, today included. That day's bar gets an amber cap.
* **7 bars**: one per day. Past days are pink and today's partial bar is white.
* **NEXT 3:45P**: local clock time of the next refresh.

## Why a clock time and not a ticking countdown

GDN frames are still images. Each refresh draws one picture and the panel holds it until the next refresh (there is no per-frame animation). Apps with a free-text or api-key input cannot refresh faster than every 300 seconds. A MM:SS countdown would freeze on whatever it said at render time. A clock time stays correct the whole time the frame is up.

## Setup

1. In the [Shopify Dev Dashboard](https://dev.shopify.com), create an app with only the `read_orders` scope, distributed to your own store.
2. Get a non-expiring offline Admin API access token using the authorization-code grant. Client-credentials tokens expire every 24 hours, and the panel cannot refresh them.
3. In the Glance Setup app, fill in:
   * **Store handle**: the part before `.myshopify.com`. Do not paste `https://` (Glance cuts settings at colons).
   * **Admin API access token**: pasted into the encrypted `api-key` field.
   * **Store time zone**: your Shopify store's zone.
   * **Cancelled orders**: `skip` (default) counts orders still standing. `count` matches the Orders figure in Shopify Analytics.

Leave the store handle or token blank to see the labeled DEMO screen.

## Data

`GET /admin/api/2026-10/orders.json?status=any&fields=id,created_at,cancelled_at,test`

The app reads no customer fields and no prices, and leaves out test orders. Paging uses `since_id` (250 per page, max 8 requests per render). It caches for 240 seconds, under the 300 second refresh.

## Screens

Live. DEMO (made-up counts, shown when the store or token is blank). Errors: TOKEN REJECTED, NEEDS READ ORDERS, STORE NOT FOUND, SHOPIFY BUSY, SHOPIFY OFFLINE.
