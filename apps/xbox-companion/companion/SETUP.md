# Self-host your Xbox Companion

Each installation serves one Microsoft/Xbox account. You run it on your own always-on PC, NAS or server. There is no service operated by the app author and no author-owned Azure credentials in this package. Each user controls their own Microsoft app registration and hosting. Your hosting, domain, electricity and any optional provider charges are your responsibility; no paid cloud deployment is required by this package.

## What you need

- Docker with Compose on an always-on machine.
- A stable public HTTPS address routed to this service through your existing reverse proxy. Glance fetches from its servers: localhost and private LAN addresses will not work as the Glance status URL.
- A personal Microsoft account with an Xbox profile and permission to register an application in Microsoft Entra.

This is the smallest supplied deployment: one container plus your existing HTTPS routing. If you do not already have public HTTPS routing, that is an additional setup step, not something this package silently purchases or configures.

## 1. Register your own Microsoft application

In Microsoft Entra App registrations, choose New registration. Name it Xbox Glance Companion and select **Personal Microsoft accounts only**. Add a **Web** redirect URI exactly matching:

```
https://YOUR-HOST/auth/callback
```

Copy its Application (client) ID. In Certificates & secrets create a client secret and save its **value** securely. Record the expiry date; replace the value in your configuration before it expires. Do not paste it into Glance, an issue, Git, or the app author's account. Do not enable Azure hosting, premium identity products, or pay-as-you-go services just to run this container.

## 2. Configure and start

Open a terminal in this `companion` directory. Copy `.env.example` to `.env` (Windows: `Copy-Item .env.example .env`; Linux/macOS: `cp .env.example .env`). Fill in PUBLIC_URL, CLIENT_ID and CLIENT_SECRET. PUBLIC_URL is the origin only, with no path.

Build the image and generate three independent keys:

```sh
docker compose build
docker compose run --rm --no-deps xbox python -c "import secrets; from cryptography.fernet import Fernet; print('ADMIN_KEY='+secrets.token_urlsafe(32)); print('READ_KEY='+secrets.token_urlsafe(32)); print('ENCRYPTION_KEY='+Fernet.generate_key().decode())"
```

Copy the generated lines into `.env`. These are secrets: do not share the terminal output. Keep ENCRYPTION_KEY backed up securely; changing it makes the saved login unreadable. Set SHOW_FRIENDS=true only if you want shared friend activity collected. It defaults off.

```sh
docker compose up -d
```

The service is published on **127.0.0.1:8080** on your host. Configure your existing HTTPS reverse proxy to forward YOUR-HOST to that address. If your proxy is itself in Docker, connect it to the companion network and use `xbox:8080` instead; its own localhost is not the host machine. Keep plain port 8080 inaccessible from the Internet. Disable proxy access logging for `/auth/callback` (authorization codes appear in its query), and never log Authorization headers. Route the callback without authentication added by the proxy; the app validates its own session and one-use state.

Protect `.env` with filesystem permissions for the machine owner. Never commit it. The Docker volume stores the refresh token encrypted; the encryption key remains in your local configuration. Anyone controlling your host/Docker installation can access these secrets.

## 3. Connect Xbox once

Open your HTTPS address, enter ADMIN_KEY, and click Connect Microsoft account. Sign in on Microsoft's page and approve the requested Xbox/offline access. The administrator key stays on your companion; the Microsoft password is entered only at Microsoft. Offline access allows this instance to refresh the connection without leaving a browser open.

The service reads a snapshot immediately and every four minutes thereafter. Device polling does not initiate additional Xbox requests. Friends, when enabled, are bounded to the first 20 contacts and only disclosed online activity is shown. This is not a complete friends feed.

## 4. Set up the Glance app

Once Xbox Companion is available in the Glance catalogue, add it and enter:

| Setting | Value |
|---|---|
| Companion status host/path | `xbox.example.com/status` (replace with your public hostname, omit `https://`) |
| Device read key | Your READ_KEY |
| Preview scenario | Live |
| Display | Your preferred card |
| Show friend activity | Enable only if SHOW_FRIENDS=true on your server |

Omit the scheme only in the Glance endpoint input: a colon can truncate the device's settings descriptor. The app adds HTTPS when requesting `/status`. Keep PUBLIC_URL and the Microsoft redirect URI as full HTTPS URLs. Existing Glance installations should remove only the `https://` prefix after updating the app, retaining their hostname/path and READ_KEY. Full HTTPS inputs remain supported for legacy settings and Studio.

The Glance display refreshes every five minutes. The companion still collects a snapshot every four minutes, the display request uses a 60-second HTTP cache, and snapshots older than five minutes show an old-data warning.

Catalogue submission is not included or completed in this package. Until the app is published, use the GDN development workflow to load `manifest.yaml` and `app.star` for testing. The companion alone does not install an app on a panel.

Never put ADMIN_KEY, ENCRYPTION_KEY, a Microsoft secret or refresh token into Glance. READ_KEY grants access to your display data; share it only with your own devices.

## Operations and troubleshooting

- **Unauthorized:** match the Glance read key to READ_KEY. `/status` intentionally refuses anonymous browser requests.
- **Connect/reconnect:** verify the client ID, secret expiry and exact Web redirect URI. Reopen the homepage and reconnect. Microsoft may revoke consent or require another sign-in.
- **Old data:** check that the container and Internet connection are running. Old snapshots retain their original timestamps. A sustained refresh failure asks you to reconnect.
- **No image/history:** privacy, missing artwork or upstream changes can limit fields. TitleHub worked in the original live test but is not a verified public production API contract. It can change or reject an installation.
- **No active game:** Last Played uses the newest returned play timestamp and server-local date; the default container timezone is UTC. Some games/devices may not report presence or history.
- **Restart/update:** `docker compose up -d --build`. Saved login survives in the named volume. Do not delete the volume unless you intend to remove it.
- **Stop:** `docker compose down`. To revoke access, remove the application's consent in your Microsoft account. Delete the local token volume only when you intend to erase the saved connection.
- **Rotate read/admin keys:** edit `.env`, then run `docker compose up -d --force-recreate`. Update Glance with the new READ_KEY. Do not casually change ENCRYPTION_KEY.

## Verification status

The original local prototype successfully fetched profile, achievements, shared friend activity, game history and artwork. The packaged service has offline authentication/storage tests. A fresh user's deployment, unattended Microsoft refresh, reverse proxy routing and actual panel delivery must still be verified end to end. No author-owned subscription or secret is required by the supplied configuration.
# Alternative without an inbound Linux port

For an HTTPS Cloudflare front end with a separate outbound-only Linux collector, see [the optional split deployment](cloudflare/README.md). The Docker instructions below remain available for an independent single-host installation.
