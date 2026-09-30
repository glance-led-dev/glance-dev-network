# Gmail app-password setup

Choose Windows below or the independent Linux/systemd installation at the end. Both use your own Gmail account and Worker; neither uses the author's server.

## Windows

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

## Linux with encrypted systemd credentials

Requires an always-on Linux host with Python 3.12+ and systemd encrypted credentials (tested on Ubuntu 24.04). Only outbound HTTPS and IMAP are needed. Windows Credential Manager blobs cannot be copied to Linux.

1. Create the non-login system account `glance-packages`, with `/var/lib/glance-packages` owned by it and mode 0700. Create the root-owned source directory `/opt/glance/packages`.
2. Copy `discover.py`, `carrier_mail.py` and `configure-linux.py` into that source directory. Linux uses only Python's standard library; Windows keyring is not required.
3. Run `sudo python3 /opt/glance/packages/configure-linux.py`. Enter your own Gmail app password, Worker `/discover` URL and WRITE_KEY. Setup verifies both connections and passes the credential JSON through a pipe to `systemd-creds encrypt`. It refuses to overwrite existing credentials. No plaintext configuration file is created.
4. Copy `glance-packages.service` and `glance-packages.timer` into `/etc/systemd/system/`. Run `sudo systemctl daemon-reload`, then `sudo systemctl start glance-packages.service`. Check its successful exit and the Worker's latest discovery time.
5. Enable the schedule with `sudo systemctl enable --now glance-packages.timer`. Check `systemctl list-timers glance-packages.timer`. It runs every 15 minutes and catches missed calendar runs after boot.
6. Verify a successful scheduled run and a successful run after reboot before disabling an existing Windows task. Keep the former installation and its credentials available for rollback.

Back up `/etc/glance/packages.cred` together with the machine's `/var/lib/systemd/credential.secret`, preferably in an encrypted VM backup. Never commit these files. Each community user provisions their own keys and account. The running service reads only its systemd credential directory and does not fall back to plaintext files.

Run `python -m unittest discover -s imap -p 'test_*.py'` from the service directory for mail parsing, upload behavior, Linux credential isolation and Windows-backend regression checks. Missing carrier notifications still produce missing or overdue data; a healthy collector does not establish that the carrier has supplied a new delivery estimate.
