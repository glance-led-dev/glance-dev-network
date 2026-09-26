"""Personal Gmail discovery: TLS IMAP, read-only mailbox, OS credential storage."""
import argparse
import email
from email import policy
from email.utils import parseaddr
import getpass
import html
import imaplib
import json
import re
import ssl
import sys
import urllib.parse
import urllib.request
from carrier_mail import notification

SERVICE = 'Glance Package Tracker'
QUERY = 'newer_than:30d -in:sent -in:spam -in:trash {subject:shipped subject:shipment subject:tracking subject:delivery from:ups.com from:fedex.com from:usps.com}'
DOMAINS = {'UPS': 'ups.com', 'FEDEX': 'fedex.com', 'USPS': 'usps.com'}


def credential_store():
    # Explicit native Windows backend: no fallback to a plaintext credential file.
    from keyring.backends.Windows import WinVaultKeyring
    return WinVaultKeyring()


def valid(carrier, value):
    code = re.sub(r'[\s-]', '', value).upper()
    patterns = {'UPS': r'1Z[A-Z0-9]{16}', 'FEDEX': r'(?:\d{12}|\d{15}|\d{20}|\d{22})', 'USPS': r'(?:\d{20,22}|[A-Z]{2}\d{9}US)'}
    return code if re.fullmatch(patterns.get(carrier, r'(?!)'), code) else None


def extract(body):
    found = {}
    def add(carrier, value):
        code = valid(carrier, value)
        if code:
            found[(carrier, code)] = {'carrier': carrier, 'tracking_code': code}
    body = html.unescape(body)
    for value in re.findall(r'https?://[^\s<>"\']+', body, re.I):
        try:
            url = urllib.parse.urlsplit(value)
            host = (url.hostname or '').lower()
        except ValueError:
            continue
        carrier = next((c for c, d in DOMAINS.items() if host == d or host.endswith('.' + d)), None)
        if not carrier:
            continue
        for key, values in urllib.parse.parse_qs(url.query).items():
            if key.lower() in ['tracknum', 'tracknums', 'tracknumbers', 'trackingnumber', 'trackingnumbers', 'tracking_id', 'trknbr', 'track', 'tlabels', 'loc']:
                for item in values:
                    for token in re.split(r'[;,\s]+', item):
                        add(carrier, token)
        for token in url.path.split('/'):
            add(carrier, token)
    for code in re.findall(r'\b1Z[A-Z0-9]{16}\b', body, re.I):
        add('UPS', code)
    plain = re.sub(r'<[^>]*>', ' ', body)
    for carrier, code in re.findall(r'\b(FedEx|USPS)\b[^\r\n]{0,45}?\btracking(?:\s+(?:number|no\.?|id))?\s*[:#-]?\s*([A-Z]{2}\d{9}US|\d{12,22})\b', plain, re.I):
        add(carrier.upper(), code)
    return list(found.values())


def parse_message(raw):
    message = email.message_from_bytes(raw, policy=policy.default)
    display, address = parseaddr(str(message.get('From', '')))
    domain = address.rpartition('@')[2].lower()
    sender = '' if any(domain == d or domain.endswith('.'+d) for d in DOMAINS.values()) else display.strip()[:150]
    parts = []
    for part in message.walk():
        if part.get_filename() or part.get_content_disposition() == 'attachment':
            continue
        if part.get_content_type() in ['text/plain', 'text/html']:
            content = part.get_content()
            if isinstance(content, str):
                parts.append(content)
    body = '\n'.join(parts)
    packages = [dict(p, sender=sender) for p in extract(body)]
    plain = re.sub(r'\s+', ' ', html.unescape(re.sub(r'<[^>]*>', ' ', body)))
    update = notification(message, domain, packages, plain)
    if update:
        packages[0]['notification'] = update
    return packages


def connect(address, password):
    client = imaplib.IMAP4_SSL('imap.gmail.com', 993, ssl_context=ssl.create_default_context(), timeout=30)
    try:
        client.login(address, password)
        # All Mail includes automatically archived shipping notifications. Spam/trash excluded by query.
        status, folders = client.list()
        mailbox = 'INBOX'
        if status == 'OK':
            for row in folders or []:
                if row and re.search(rb'(?:^|[\s(])\\All(?:[\s)]|$)', row):
                    match = re.search(rb'\)\s+(?:"[^"]*"|NIL)\s+(.+)$', row)
                    if match:
                        mailbox = match.group(1).decode('ascii')
                        break
        status, _ = client.select(mailbox, readonly=True)
        if status != 'OK':
            raise RuntimeError('Mailbox could not be opened')
        return client
    except Exception:
        client.logout()
        raise


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *args, **kwargs):
        return None


def upload(endpoint, key, packages, complete):
    request = urllib.request.Request(endpoint, data=json.dumps({'packages': packages, 'complete': complete}).encode(), headers={'Authorization': 'Bearer '+key, 'Content-Type': 'application/json', 'User-Agent': 'Glance-Package-Discovery/1.0'}, method='POST')
    with urllib.request.build_opener(NoRedirect()).open(request, timeout=30) as response:
        if response.status != 200:
            raise RuntimeError('Upload failed')


def sync(store):
    values = {k: store.get_password(SERVICE, k) for k in ['email', 'app-password', 'endpoint', 'write-key']}
    if not all(values.values()):
        raise RuntimeError('Run secure setup first')
    client = connect(values['email'], values['app-password'])
    count = 0
    try:
        status, result = client.uid('SEARCH', None, 'X-GM-RAW', '"'+QUERY+'"')
        if status != 'OK':
            raise RuntimeError('Mail search failed')
        for uid in (result[0] or b'').split():
            status, result = client.uid('FETCH', uid, '(BODY.PEEK[])')
            if status != 'OK':
                raise RuntimeError('Message read failed')
            raw = next((item[1] for item in result if isinstance(item, tuple)), None)
            if raw is None:
                raise RuntimeError('Message body unavailable')
            packages = parse_message(raw)
            for offset in range(0, len(packages), 25):
                batch = packages[offset:offset+25]
                upload(values['endpoint'], values['write-key'], batch, False)
                count += len(batch)
        # Only signal healthy discovery once the entire mailbox search completed successfully.
        upload(values['endpoint'], values['write-key'], [], True)
    finally:
        client.logout()
    print('Discovery completed. Package references processed:', count)


def setup(store, address):
    address = (address or store.get_password(SERVICE, 'email') or input('Gmail address: ')).strip()
    if not re.fullmatch(r'[^\s@]+@[^\s@]+\.[^\s@]+', address):
        raise RuntimeError('Invalid email address')
    password = getpass.getpass('Gmail app password (hidden): ').replace(' ', '')
    client = connect(address, password)
    client.logout()
    store.set_password(SERVICE, 'email', address)
    store.set_password(SERVICE, 'app-password', password)
    print('Gmail verified. Credentials saved in Windows Credential Manager.')
    endpoint = input('Worker HTTPS /discover URL (leave blank until deployed): ').strip()
    if endpoint:
        url = urllib.parse.urlsplit(endpoint)
        if url.scheme != 'https' or not url.hostname or url.path != '/discover' or url.username or url.password or url.query or url.fragment:
            raise RuntimeError('Use the HTTPS /discover URL without query parameters')
        key = getpass.getpass('Worker WRITE_KEY (hidden): ').strip()
        if not key:
            raise RuntimeError('Write key required')
        upload(endpoint, key, [], False)
        store.set_password(SERVICE, 'endpoint', endpoint)
        store.set_password(SERVICE, 'write-key', key)
        print('Feed connection verified. Ready to sync.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--setup', action='store_true')
    parser.add_argument('--email', default='')
    args = parser.parse_args()
    try:
        vault = credential_store()
        setup(vault, args.email) if args.setup else sync(vault)
    except Exception:
        # Never print IMAP/server errors, credentials or message content.
        print('Connection/setup failed. Check the connection settings and try again.', file=sys.stderr)
        sys.exit(1)
