# Fantrax connection setup

## Get your Fantrax GLANCE token

Before configuring this app on your GLANCE, you need a Fantrax GLANCE token.

1. Open `https://fantrax-public.mdarpino.workers.dev/connect` in a web browser.
2. Sign in with your Fantrax account.
3. After a successful connection, copy the GLANCE token shown on the page.
4. Add or configure **Fantrax Hockey Standings** on your GLANCE and enter:
   - **Fantrax League ID** - the league ID from your Fantrax league URL.
   - **Fantrax GLANCE Token** - the token generated in step 3.

Your Fantrax password is used only for the login attempt and is not stored by the connector.

Keep the GLANCE token private. It is entered as an encrypted `api-key` input.

The app refreshes every 300 seconds and supports up to 14 teams / 7 pages.

## Privacy and security

This app uses a Cloudflare Worker to connect GLANCE to Fantrax.

- Your Fantrax password is used only during the login attempt and is not stored.
- The resulting Fantrax session cookies are encrypted before being stored.
- The encryption key is stored as a Cloudflare Worker secret.
- Your GLANCE token is a random credential; only its SHA-256 hash is stored by the service.
- League data is cached for approximately 5 minutes.
- Team logos are fetched and processed by the Worker so Fantrax session credentials are never exposed to the GLANCE app.
- Treat your GLANCE token like a password. Anyone with the token may be able to read Fantrax data available through that connection.

