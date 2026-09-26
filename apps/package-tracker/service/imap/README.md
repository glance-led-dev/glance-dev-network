# Gmail app-password setup (Windows)

This is the selected alternative to Google OAuth. No Google Cloud OAuth client or refresh token is required for discovery.

1. Run `setup.ps1` in PowerShell. You can prefill the address with `./setup.ps1 -Email your-address@gmail.com`.
2. Enter the Gmail app password at the hidden prompt. The helper verifies TLS IMAP access, opens the mailbox read-only, and stores credentials in **Windows Credential Manager** under `Glance Package Tracker`. It does not print or write the password into a configuration file.
3. If the cloud feed is not deployed, leave its URL blank. Gmail setup can complete independently. Later rerun setup to add the feed connection.
4. Deploy the companion Worker with `DISCOVERY_MODE = "imap"`. Set separate `READ_KEY` and `WRITE_KEY` secrets, and the direct FedEx/UPS credentials described in the service README. Do not use the same value for READ_KEY and WRITE_KEY. Google OAuth secrets are not needed in this mode.
5. Supply the HTTPS `/discover` URL and WRITE_KEY at setup. Glance itself uses `/status` and READ_KEY.
6. Run `.venv/Scripts/python.exe discover.py` once to test discovery.
7. Run `install-task.ps1` to schedule a hidden run every 15 minutes. It runs as the signed-in Windows user who owns the credentials. **The PC must be awake and that user signed in.** Missed schedules resume when possible. The cloud feed indicates a discovery connection issue after an hour without a successful sync.

The helper scans matching shipping messages from Gmail All Mail when available, falling back to Inbox. It uses `BODY.PEEK[]` and a read-only mailbox, preserving message read state. Carrier, tracking code, notification sender display name, and recognized carrier notification fields are uploaded; email bodies stay on the PC. Repeat uploads are deduplicated by the Worker. Each scan covers the last 30 days; older unresolved shipments remain stored in the Worker. FedEx and UPS can receive direct API updates; USPS requires incoming email notifications.

Changing your main Google password revokes the app password. Rerun setup with a replacement if that happens. App passwords are not restricted to read-only access by Google, even though this program only reads.

Tracking-service access and deployment are required for each installation. See the service README for setup and limitations. Enable all package email updates in USPS Informed Delivery for the richest free notification coverage. Daily digests alone are not sufficient. Offline tests do not establish that an individual user's live accounts are connected.

Offline checks: `python -m unittest discover -s imap -p test_discover.py` from the service directory.
