"""Conservative carrier notification parsing. Email is data, never instructions."""
import re
from datetime import datetime, timezone
from email.utils import parsedate_to_datetime

SUBJECT_STATES = [
    (r'\b(?:was |has been )?delivered\b', 'delivered', 'DELIVERED'),
    (r'\bout for delivery\b', 'out_for_delivery', 'OUT FOR DELIVERY'),
    (r'\b(?:delivery attempted|delivery attempt)\b', 'failure', 'DELIVERY ATTEMPTED'),
    (r'\b(?:delayed|arriving late)\b', 'failure', 'DELAYED'),
    (r'\b(?:in transit|on the way)\b', 'in_transit', 'IN TRANSIT'),
    (r'\b(?:scheduled|expected delivery|arriving)\b', 'unknown', 'DELIVERY EXPECTED'),
]

def notification(message, domain, packages, plain):
    # A digest can mention different states for different parcels. Never merge them.
    if len(packages) != 1:
        return None
    p = packages[0]
    root = {'UPS': 'ups.com', 'USPS': 'usps.com'}.get(p['carrier'])
    if not root or not (domain == root or domain.endswith('.' + root)):
        return None
    # Trust only Gmail's top Authentication-Results header and aligned DMARC.
    auth = str(message.get('Authentication-Results', ''))
    if not re.match(r'^\s*mx\.google\.com\s*;', auth, re.I):
        return None
    aligned = re.search(r'\bdmarc=pass\b[^;]*\bheader\.from=([^\s;]+)', auth, re.I)
    auth_domain = aligned[1].lower().rstrip('.') if aligned else ''
    if not (auth_domain == root or auth_domain.endswith('.' + root)):
        return None
    subject = str(message.get('Subject', '')).lower()
    if re.search(r'\b(?:digest|not delivered|undelivered|could not|unable to|will be delivered|to be delivered)\b', subject):
        return None
    state = next(((status, label) for pattern, status, label in SUBJECT_STATES if re.search(pattern, subject)), None)
    if not state:
        return None
    try:
        date = parsedate_to_datetime(str(message.get('Date', '')))
        if date.tzinfo is None:
            return None
        timestamp = int(date.timestamp())
        if timestamp <= 0 or timestamp > datetime.now(timezone.utc).timestamp() + 300:
            return None
    except (ValueError, TypeError, OverflowError):
        return None
    result = {'status': state[0], 'message': state[1], 'notified_at': timestamp,
              'expected_date': '', 'delivery_window': ''}
    # Only a date directly labelled as expected/estimated/scheduled delivery.
    months = r'(?:Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:t(?:ember)?)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)'
    match = re.search(r'(?i)(?:expected|estimated|scheduled)\s+delivery(?:\s+date)?\s*:?\s*(?:on\s+)?(?:(?:Mon|Tue|Wed|Thu|Fri|Sat|Sun)[a-z]*\s*,?\s*)?(' + months + r'\s+\d{1,2}(?:,?\s+20\d{2})?|\d{1,2}\s+' + months + r'(?:,?\s+20\d{2})?)\b', plain)
    if match and state[0] != 'delivered':
        value = re.sub(r'(?i)\bSept\b', 'Sep', match[1].replace(',', ''))
        years = [None] if re.search(r'20\d{2}$', value) else [date.year-1, date.year, date.year+1]
        candidates = []
        for year in years:
            for fmt in ('%B %d %Y', '%b %d %Y', '%d %B %Y', '%d %b %Y'):
                try:
                    expected = datetime.strptime(value if year is None else value+' '+str(year), fmt)
                    if abs((expected.date()-date.date()).days) <= 31:
                        candidates.append(expected)
                except ValueError:
                    pass
        if candidates:
            result['expected_date'] = min(candidates, key=lambda d:abs((d.date()-date.date()).days)).strftime('%Y-%m-%d')
    times = set(re.findall(r'(?i)\bby\s+(\d{1,2}:\d{2})\s*([ap]m)\b', plain))
    if len(times) == 1 and result['expected_date']:
        clock, meridiem = next(iter(times))
        hour, minute = map(int, clock.split(':'))
        if 1 <= hour <= 12 and minute < 60:
            result['delivery_window'] = 'BY ' + clock + ' ' + meridiem.upper()
    return result
