# Xbox Companion: your own Cloudflare front end and Linux collector

This is an optional single-account deployment for Xbox Companion. Each person deploys their own Worker, Linux collector, Microsoft application registration and keys. It uses no author's endpoint, Microsoft app ID, credentials, server or subscription. Catalogue publication is separate from deploying this service.

## What runs where

- Your Cloudflare Worker provides the HTTPS sign-in page and protected `/status` feed. Its Durable Object stores display snapshots and short-lived, encrypted authorization-code handoffs.
- Your always-on Linux server collects Xbox profile, presence, achievements, history and artwork every four minutes. Microsoft access and refresh tokens never enter the display feed. Refresh tokens are encrypted on that server.
- Your Microsoft Entra application registration identifies your installation during sign-in. Azure application hosting is not needed.
- Your Glance device reads your Worker using its separate read key. Reading the feed does not start Xbox API requests. Friends default off. To opt in, set SHOW_FRIENDS="true" in the Worker's vars and enable friend collection when provisioning Linux; disclosed activity is bounded to 20 contacts.

You are responsible for your own hosting and provider limits. This does not route community traffic through another user's account. The original standalone Docker option remains available in the [Xbox community submission](https://github.com/glance-led-dev/glance-dev-network/pull/829).

## 1. Create your personal Microsoft registration

Register a Web application for personal Microsoft accounts. Add exactly `https://YOUR-WORKER.YOUR-SUBDOMAIN.workers.dev/auth/callback` as its Web redirect URI. Save its client ID, client-secret value and expiration privately. Do not enable implicit flow or create paid Azure hosting resources for this service.

## 2. Deploy your Cloudflare front end

Install Node.js and Wrangler, and sign in to **your own** Cloudflare account with `npx wrangler login`. Copy `wrangler.example.toml` to `wrangler.toml`. Set your own Worker name, PUBLIC_URL and Microsoft CLIENT_ID. Keep the Durable Object binding and SQLite migration.

Run `node test-worker.mjs`, then `npx wrangler deploy`. Initially it rejects requests until its secrets are provisioned.

Generate four independent random values of at least 32 bytes for ADMIN_KEY, READ_KEY, WRITE_KEY and HANDOFF_KEY. HANDOFF_KEY must be base64url-encoded 32-byte data. Store them in your password manager and configure them using `npx wrangler secret put NAME` for each name. These commands prompt for hidden input. Do not put secrets in wrangler.toml or shell arguments.

Disable Worker request logging for this deployment: OAuth callback URLs contain one-use codes. This package sets observability to false. Do not enable log tails or third-party request logging during sign-in.

## 3. Install the collector on your Linux server

Requires Python 3.12+, systemd with encrypted credentials (Ubuntu 24.04 works), and outbound HTTPS. No inbound server port or public domain for your Linux host is needed.

1. Create a non-login system account `glance-xbox` with home `/var/lib/glance-xbox`. Create that directory owned by this account with mode 0700.
2. Copy `collector.py`, `xbox.py`, and `requirements.txt` to `/opt/glance/xbox` as root-owned source. Create `/opt/glance/xbox/venv` using `python3 -m venv` and install requirements into it.
3. Run `sudo python3 configure-linux.py`. It prompts for your own PUBLIC_URL, client ID, client-secret value, WRITE_KEY and HANDOFF_KEY. Use the same write and handoff keys as your Worker. It generates a fresh local encryption key and saves only a systemd-encrypted credential file. It refuses to overwrite existing credentials.
4. Install `glance-xbox.service` into `/etc/systemd/system/`, then run `sudo systemctl daemon-reload` and `sudo systemctl enable --now glance-xbox`.

Keep a secure backup of `/var/lib/systemd/credential.secret`, `/etc/glance/xbox.cred`, and `/var/lib/glance-xbox/refresh.enc`, or back up the entire VM. The systemd credential is bound to that machine's host key. The original Microsoft secret and Cloudflare keys should also be in your password manager. Do not publish these files.

## 4. Connect once

Visit your Worker homepage, enter your ADMIN_KEY, and choose Connect Microsoft account. Sign in and approve continued access. The collector exchanges the one-use encrypted handoff, stores the refresh token encrypted locally, and publishes the first snapshot. The Microsoft secret is sent only to Microsoft's token endpoint. A lost or expired handoff requires starting sign-in again.

The optional `/admin/ticket` endpoint supports a one-use setup ticket valid for five minutes, authenticated with ADMIN_KEY. `/start` accepts that ticket in a POST body; do not put administrator keys into URLs.

## 5. Configure and verify Glance

Use `YOUR-WORKER.YOUR-SUBDOMAIN.workers.dev/status` as the device endpoint (omit `https://` in the device settings descriptor), READ_KEY as the encrypted device read key, and Live as the preview scenario. Never enter the admin key, write key, handoff key, encryption key, Microsoft secret or tokens into Glance.

Verify a fresh authenticated `/status` response, successful collector updates, an automatic refresh after four minutes, and recovery after reboot. An anonymous `/status` request must return 401. The catalogue app refreshes every five minutes and shows old-data warnings for stale snapshots. Catalogue merge and physical-device delivery are separate from server health.

## Operations and limitations

- Use `systemctl status glance-xbox` and its journal. Logs contain stages and error types, not token values or callback URLs.
- Expired/revoked Microsoft credentials require updating the encrypted service credential or reconnecting. Never silently generate a new encryption key for an existing token file.
- Xbox TitleHub/game-history support is based on the existing application's live probe; it is not a guaranteed unrestricted Microsoft production API. Availability can vary per account and registration.
- Artwork is bounded and fetched only from HTTPS Xbox/Microsoft hosts. Missing data remains missing.
- Stop the collector before restoring its token files or starting another copy. Deploy one collector per installation.
- The original independent Docker deployment in GitHub is still supported by its own setup instructions. This optional split deployment does not change that public package.

Sources: [Microsoft redirect URIs](https://learn.microsoft.com/en-us/entra/identity-platform/how-to-add-redirect-uri), [Cloudflare Worker secrets](https://developers.cloudflare.com/workers/configuration/secrets/).
